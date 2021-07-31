import ReactDOM from 'react-dom';
import React, { Component } from 'react'
import Web3 from 'web3'
import './App.css'

import PropertyListings from './components/PropertyListings';


class App extends Component {
  render() {
    return (
        <PropertyListings></PropertyListings>
    );
  }
}
export default App;