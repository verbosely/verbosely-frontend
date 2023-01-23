import React, { Component } from 'react';
import searchIcon from './../images/search_FILL0_wght700_GRAD200_opsz48.svg';
import axios from 'axios';
import { Form, Outlet, redirect } from 'react-router-dom';
import QueryCleaner from './../classes/queryCleaner';

const axiosConfig = axios.create({
   // Get public IPv4 address from .env file.
   baseURL: `http://${process.env.REACT_APP_PUBLIC_IPV4}`
});
      
const getLexicographicData = (word) => {
   return axiosConfig.get('/get-lexicographic-data/', {
      params: {
	 word: word
      }
   });
};

const wordSearchHomeLoader = async ({ request }) => {
   let url = new URL(request.url);
   let searchTerm = url.searchParams.get('wordSearch');
  
   // If searchTerm is not null, undefined, or an empty string, then the 
   // body of the if-statement is executed.
   if (searchTerm) {

      // Instantiate a QueryCleaner object to evaluate and clean
      // searchTerm.
      const queryCleaner = new QueryCleaner(searchTerm);

      // Remove all white space characters from searchTerm.
      if (queryCleaner.hasWhiteSpace()) searchTerm = queryCleaner.removeWhiteSpace();
      
      // If searchTerm is not an empty string after cleaning and it has
      // proper length, then send a GET HTTP request to the server to 
      // retrieve lexicographic data for the user-inputted search parameter 
      // of the URL.
      if (searchTerm && queryCleaner.hasProperLength()) {
	 try{
	    const response = await getLexicographicData(searchTerm);
	    return redirect(`${searchTerm}`);  
	 } catch (error) {
	    return redirect(`${searchTerm}/${error.response.status}`);
	 }
      };
   } else return null;

};

class WordSearchHome extends Component {

   constructor(props) {
      super(props);
      this.state = {value: ''};
      this.handleChange = this.handleChange.bind(this);
   }

   handleChange(event) {
      this.setState({value: event.target.value});
   }

  render() {

      return (
	 <>
	    <header className="header vertical-flex">
	       <h1 className="heading-1">A Dictionary of the English Language</h1>
	       <Form acceptCharset="utf-8" 
		  autoCapitalize="none" 
		  autoComplete="off" 
		  method="get"
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
			name="wordSearch"
			value={this.state.value}
			onChange={this.handleChange}
		     />
		     <input className="search-button-box"
			alt="Get lexicographic data" 
			src={searchIcon} 
			type="image" 
		     />
		  </div>
	       </Form>
	    </header>
	    <Outlet />
	 </>
      );
   }
}

export { WordSearchHome as default, wordSearchHomeLoader };
