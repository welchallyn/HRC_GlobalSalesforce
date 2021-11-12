({
  // Your renderer method overrides go here
  rerender: function(cmp, helper) {
    this.superRerender();
    //alert ("re rendering");
    // do custom rerendering here
  },
  render : function(cmp, helper) {
    var ret = this.superRender();
    // do custom rendering here
    //alert ("rendering");
    return ret;
      
},
   
});