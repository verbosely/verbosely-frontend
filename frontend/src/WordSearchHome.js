import React, { Component } from 'react';
import searchIcon from './images/search_FILL0_wght700_GRAD200_opsz48.svg';
import './WordSearchHome.css';
import axios from 'axios';

class WordSearchHome extends Component {

   constructor(props) {
      super(props);
      this.axiosConfig = axios.create({
	 baseURL: 'http://127.0.0.1'
      });
      this.state = {value: ''};
      this.handleChange = this.handleChange.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
   }

   handleChange(event) {
      this.setState({value: event.target.value});
   }

   handleSubmit(event) {
      event.preventDefault();
      this.axiosConfig.get('/get-lexicographic-data/', {
	 params: {
	    word: this.state.value
	 }
      });
   }

   render() {
      return (
	 <header className="header vertical-flex">
	    <h1 className="heading-1">A Dictionary of the English Language qqq</h1>
	    <form acceptCharset="utf-8" 
	       autoCapitalize="none" 
	       autoComplete="off" 
	       method="get"
	       onSubmit={this.handleSubmit}
	    >
	       <label className="label" 
		  htmlFor="dictionarySearch"
	       >
		  Search for a Word
	       </label>
	       <div className="horizontal-flex">
		  <input className="search-button-box search-box"
		     type="text" 
		     id="dictionarySearch"
		     value={this.state.value}
		     onChange={this.handleChange}
		  />
		  <input className="search-button-box"
		     alt="Get lexicographic data" 
		     src={searchIcon} 
		     type="image" 
		  />
	       </div>
	    </form>
	 </header>
      );
   }
}

export default WordSearchHome;
