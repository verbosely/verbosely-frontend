class QueryCleaner {
   constructor(query) {
      this.query = query;
   }

   hasWhiteSpace() {
      if (this.query.match(/\s/g) == null) return false;
      else return true;
   }

   removeWhiteSpace() {
      return this.query.replace(/\s/g, '');
   }
}

export default QueryCleaner;
