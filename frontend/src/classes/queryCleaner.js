class QueryCleaner {
   constructor(query) {
      this.query = query;
   }

   hasWhiteSpace() {
      if (this.query.match(/\s/g) == null) return false;
      else return true;
   }

   removeWhiteSpace() {
      this.query = this.query.replace(/\s/g, '');
      return this.query;
   }

   hasProperLength() {
      if (this.query.length < 40) return true;
      else return false;
   }

}

export default QueryCleaner;
