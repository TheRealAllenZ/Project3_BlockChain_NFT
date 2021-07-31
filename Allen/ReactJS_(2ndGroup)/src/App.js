import logo from './logo.svg';
import Booking from './Components/BookingManager';
import Overlay from './Components/Overlay';
import Backdrop from './Components/Backdrop';
import './App.css';

function App() {
  return (
    <div>
      <h1>Adieu Coin</h1>
      <Booking text = 'Book'/>
      <Booking text = 'Landlords'/> 
      <Overlay/>
      <Backdrop/>
    </div>
    
  );
}

export default App;
