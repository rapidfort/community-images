import React, { useState, useEffect } from 'react';
import './App.css';

const baseUrl = '/api/date';

const GetRemoteDate = () => {
    const [ date, setDate ] = useState([])
    useEffect(() => {
        function getDate() {
            fetch(baseUrl)
                .then(output => output.json())
                .then(output => setDate(output))
            }
        getDate()
        const interval = setInterval(() => getDate(), 50000)
        return () => {
            clearInterval(interval);
        }
    }, [])

    return (
        <div> {date} </div>
    )

}

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <GetRemoteDate />
      </header>
    </div>
  );
}

export default App;
