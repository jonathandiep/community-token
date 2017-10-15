import React, { Component } from 'react';
import { Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';

import AppNavbar from './components/AppNavbar';
import Error from './components/Error';
import ConferenceContract from '../build/contracts/Conference.json';
import getWeb3 from './utils/getWeb3'

const contract = require('truffle-contract')
const _ = require('lodash');

const TICKET_PRICE = 1;

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      accounts: [],
      userAddress: '',
      contract: {},
      contractAddress: '',
      error: {
        display: false,
        text: 'Invalid transaction'
      },
      modal: false,
      web3: {},
    }

    this.toggle = this.toggle.bind(this);
    this.purchaseTicket = this.purchaseTicket.bind(this);
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    getWeb3
      .then(results => {
        this.setState({ web3: results.web3 })
        console.log(this.state.web3);

        // Instantiate contract once web3 provided.
        this.instantiateContract();
      })
      .catch(() => console.log('Error finding web3.'));
  }

  /**
   * Example here is to display balance of the smart contract
   *
   * @memberof App
   */
  instantiateContract() {
    const accounts = this.state.web3.eth.accounts;
    this.setState({ accounts });
    const c = contract(ConferenceContract);
    c.setProvider(this.state.web3.currentProvider);

    c.deployed()
      .then((contract) => {
        this.setState({ contract });
        this.setState({ contractAddress: this.state.contract.address });
        this.setState({ userAddress: this.state.web3.eth.accounts[0] });

        if (!_.isEmpty(this.state.userAddress)) {
          this.updateBalance();
        }
      });
  }

  /**
   * Function for an account to buy a ticket
   *
   * @param {any} conference - deployed conference data that is passed in
   * @param {any} accounts
   * @memberof App
   */
  async buyTicket(contract, account, ticketPrice) {
    try {
      await contract.buyTicket({ from: account, value: ticketPrice });
      this.setState({ error: Object.assign({}, this.state.error, { display: false }) });
    } catch(e) {
      console.error(`Unable to buy ticket: ${e}`);
      this.setState({ error: Object.assign({}, this.state.error, { display: true }) });
    }
  }

  /**
   * Function to refund a ticket
   *
   * @param {any} conference
   * @param {any} accounts
   * @memberof App
   */
  async refundTicket(contract, accounts) {
    const ticketPrice = this.state.web3.toWei(0.05, 'ether');

    try {
      await contract.refundTicket(accounts[1], ticketPrice, { from: accounts[0] });
    } catch(e) {
      console.error(`Unable to refund ticket: ${e}`);
    }
  }

  render() {
    let buyer;
    let button;
    let error;

    if (!_.isEmpty(this.state.userAddress)) {
      buyer = (
        <div>
          <h5>Account Balance: {this.state.userBalance} ETH</h5>
          <p>Cost of a Ticket: {TICKET_PRICE} ETH</p>
        </div>
      );

      // TODO: Account for gas?
      if (this.state.userBalance > TICKET_PRICE) {
        button = <Button color="primary" onClick={this.toggle}>Buy a Ticket</Button>;
      } else {
        button = <Button color="danger" disabled={true}>Not Enough ETH</Button>;
      }
    } else {
      button = <Button color="primary" disabled={true}>Buy a Ticket</Button>;
    }

    if (this.state.error.display) {
      error = <Error message={this.state.error.text} />
    }

    return (
      <div className="App">
        <AppNavbar />
        {error}

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h4>Contract Address:</h4>
              <p>{this.state.contractAddress}</p>
              <hr />
              {buyer}
              {button}
              {this.buyTicketModal()}
            </div>
          </div>
        </main>
      </div>
    );
  }

  toggle() {
    this.setState({ modal: !this.state.modal });
  }

  buyTicketModal() {
    return (
      <div>
        <Modal isOpen={this.state.modal} toggle={this.toggle} className={this.props.className}>
          <ModalHeader toggle={this.toggle}>Buy Ticket</ModalHeader>
          <ModalBody>
            <p>Are you sure you want to purchase a ticket?</p>
            <p>It will cost {TICKET_PRICE} ETH</p>
          </ModalBody>
          <ModalFooter>
            <Button color="success" onClick={this.purchaseTicket}>Purchase</Button>{' '}
            <Button color="secondary" onClick={this.toggle}>Cancel</Button>
          </ModalFooter>
        </Modal>
      </div>
    )
  }

  async purchaseTicket() {
    const ticketPrice = this.state.web3.toWei(TICKET_PRICE, 'ether');

    await this.buyTicket(this.state.contract, this.state.userAddress, ticketPrice);

    this.toggle();
    this.updateBalance();
  }

  updateBalance() {
    this.state.web3.eth.getBalance(this.state.userAddress, (err, result) => {
      if (err) {
        console.error(err);
      } else {
        const userBalance = this.state.web3.fromWei(result.toNumber(), 'ether');
        this.setState({ userBalance });
      }
    });
  }
}

export default App
