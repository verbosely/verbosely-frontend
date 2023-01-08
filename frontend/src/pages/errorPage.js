import { useRouteError, Link } from "react-router-dom";

export default function ErrorPage() {
   const error = useRouteError();
   console.error(error);

   return (
      <header className="header vertical-flex">
	 {error.status === 404 &&
	    <>
	       <h1 className="heading-1">HTTP Response Status Code 404</h1>
	       <p className="paragraph">
		  <strong>Requested Resource Not Found</strong><br /><br />
		  "{error.data.match([/.*/])[0].slice(1, -1)}" is either not in&nbsp;
		  <Link 
		     to='.' 
		     draggable='false'
		  >
		     Webster's New International Dictionary of the English Language
		  </Link>
		  , or its lexicographic data has not been curated yet.
	       </p>
	    </>
	 }
      </header>
   );
}
