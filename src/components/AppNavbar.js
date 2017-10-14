import React, { Component } from 'react';
import { Navbar, NavbarBrand } from 'reactstrap';

export default class AppNavbar extends Component {
  render() {
    return (
      <div>
        <Navbar color="faded" light expand="md">
          <NavbarBrand href="/">Ticket</NavbarBrand>
        </Navbar>
      </div>
    );
  }
}
