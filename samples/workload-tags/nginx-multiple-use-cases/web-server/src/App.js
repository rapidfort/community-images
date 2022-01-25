import React, { useState, useEffect } from 'react';
import './App.css';

const baseUrl = '/api/date';

const GetRemoteDate = () => {

    const [ date, setDate ] = useState("")
    const [ server, setServer ] = useState("")

    useEffect(() => {
        function getDate() {
            fetch(baseUrl)
                .then(res => res.json())
                .then(res => { setServer(res.server); setDate(res.date) })
            }
        getDate()
        const interval = setInterval(() => getDate(), 1000)
        return () => {
            clearInterval(interval);
        }
    }, [])

    return (
        <div>
            {server}
            <br/>
            {date}
        </div>
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
