import React, { Component } from 'react';

class UserInfo extends Component {

  constructor(props) {
    super(props);
    this.state = {
      name: "",
      email: "",
      id: "",
      organization: "",
      phone: "",
      group: "",

      
    };
    this.props.keycloak.loadUserInfo().then(userInfo => {
        console.log(userInfo)
        this.setState({
            name: userInfo.name, 
            email: userInfo.email, 
            id: userInfo.sub, 
            organization: userInfo.organization,
            phone: userInfo.phone,
            group: userInfo.group

        })
    });
  }

  render() {
    return (
      <div className="UserInfo">
        <p>Name: {this.state.name}</p>
        <p>Email: {this.state.email}</p>
        <p>ID: {this.state.id}</p>
        <p>Organization: {this.state.organization}</p>
        <p>Phone: {this.state.phone}</p>
        <p>Group: {this.state.group}</p>

      </div>
    );
  }
}
export default UserInfo;