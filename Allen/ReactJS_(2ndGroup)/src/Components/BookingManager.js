import {useState} from 'react';

funtion Booking(props) {
const [overlayIsOpen, setOverlayIsOpen] = useState(false);

    function enterPage() {
        console.log('Clicked');
        console.log(props.text);
        }
    return (
        <div className='card'>
                <h2>{props.text}}</h2>
                <div className='actions'>
                    <button className='btn' onClick={enterPage}>Enter Now</button>
                </div>  
        </div>
    );
}

export default Booking;