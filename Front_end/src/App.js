import ReactDOM from 'react-dom';
import React, { Component } from 'react'
import Web3 from 'web3'
import './App.css'
import { LISTING_ABI, LISTING_ADDRESS } from './config'
import { unstable_renderSubtreeIntoContainer } from 'react-dom'

import Header from './components/Header';
import Footer from './components/Footer';
import PropertyListings from './components/PropertyListings';


class App extends Component {
  async loadBlockchainData() {
    const web3 = new Web3(Web3.givenProvider || "http://localhost:8545")
    const accounts = await web3.eth.getAccounts()
    this.setState({ account: accounts[0] })
    const listings = new web3.eth.Contract(LISTING_ABI, LISTING_ADDRESS)
    this.setState({ listings })
    const propertyCount = await listings.methods.getCount().call()
    this.setState({ propertyCount })
    for (var i = 0; i <= propertyCount; i++) {
      const property = await listings.methods.getDetails(i).call()
      this.setState({
        properties: [...this.state.properties, property]
      })
    }
}
 
  constructor(props) {
    super(props)
    this.state = {
      account: '',
      propertyCount: 0,
      properties: []
    }
}    
render() {
    return (
      <div>
        <nav>
        </nav>
        <Header/>
        <div className="container-fluid">
          <main role="main" className="col-lg-12 d-flex justify-content-center">
                      <div id="loader" className="text-center">
                        <p className="text-center">Loading...{this.state.propertyCount}</p>
                      </div>
          </main>
        <div className="row">
          <PropertyListings properties= {this.state.properties}></PropertyListings>
        </div>
      </div>
      <Footer></Footer>
    </div>
  );
  };
}

export default App;