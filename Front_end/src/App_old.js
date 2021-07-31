import ReactDOM from 'react-dom';
import React, { Component } from 'react'
import Web3 from 'web3'
import './App.css'

import Header from './components/Header';
import Footer from './components/Footer';


import PropertyListings from './components/PropertyListings';


class App extends Component {
  render() {
    return (
        <div>
        <Header></Header>
        <PropertyListings></PropertyListings>
        <Footer></Footer>
        </div>
    );
  }
}
export default App;