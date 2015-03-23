(function(ns){

	ns.React = ns.React || {};

	ns.React.Header = React.createClass({displayName: 'Header',
		render: function(){
			return (
				React.createElement('div', { className: "page-header" }, this.props.title)
			);
		}
	});

	return ns;

}( WD || {} ));