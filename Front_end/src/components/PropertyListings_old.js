import React, { Component } from 'react'
import Web3 from 'web3'
import './PropertyListings.css'
import { LISTING_ABI, LISTING_ADDRESS } from '../config'


class PropertyListings extends Component {
  componentWillMount() {
    this.loadBlockchainData()
  }
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
          <div className="container-fluid">
            <div className="row">
              <main role="main" >
                <div id="loader" className="text-center">
                  <p align="center">Loading...{this.state.propertyCount}</p>
                
                </div>
                <div id="content">
                  <ul id="completedTaskList" className="list-unstyled">
                  <ul id="taskList" className="list-unstyled">
                    { this.state.properties.map((property, key) => {
                      return(
                        <table>
                        <tr>
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{property.token_id}</span>
                            </div>
                          </td> 
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{property.propertyOwner}</span>
                            </div>
                          </td>
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{property.rentFee}</span>
                            </div>
                          </td>
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{property.nonRefundableFee}</span>
                            </div>
                          </td>
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{property.depositFee}</span>
                            </div>
                          </td>
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{Intl.DateTimeFormat('en-US', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' }).format(property.startAvailability) }</span>
                            </div>
                          </td>
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{Intl.DateTimeFormat('en-US', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' }).format(property.endAvailability)}</span>
                            </div>
                          </td>
    
                          <td>
                            <div className="taskTemplate" className="checkbox" key={key}>
                            <span className="content">{property.propertyStatus}</span>
                            </div>
                            
                          </td>
    
                          </tr>  
                        </table>
                        
                      )
                    })}
                  </ul>
                  
                  </ul>
                </div>
              </main>
            </div>
          </div>
      );
      }
    }
    
    export default PropertyListings;