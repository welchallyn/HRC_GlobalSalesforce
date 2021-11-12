({
	reload : function(component, event, helper) {
        window.setTimeout( $A.getCallback(function() {
            window.location.reload();
        }), 3000 );  
    }
})