import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from "react-router-dom"
import './index.css';
import './stylesheets/wordSearchHome.css';
import './stylesheets/errorPage.css';
import WordSearchHome, { wordSearchHomeLoader } from './pages/wordSearchHome';
import reportWebVitals from './reportWebVitals';
import ErrorPage from './pages/errorPage';
import WordData from './pages/wordData';

const router = createBrowserRouter([
   {
      path: "/",
      element: <WordSearchHome />,
      id: "root",
      loader: wordSearchHomeLoader,
      errorElement: <ErrorPage />,
      children: [
	 {
	    path: ":word",
	    element: <WordData />,
	 },
      ],
   },
]);


ReactDOM.createRoot(document.getElementById('root')).render(
   <React.StrictMode>
      <RouterProvider router={router} />
   </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
