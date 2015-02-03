/**
* @displayname MotorSportReg (MSR) CFML API Wrapper
* @description You need at least an organizer account for http://api.motorsportreg.com/. Get your username and password from https://www.motorsportreg.com/index.cfm/event/public.signup.
* @hint        Allows CF developers to use the MotorSportReg (MSR) API easily. Learn more at http://api.motorsportreg.com/.
* @output      FALSE
* @accessors   TRUE
*
* @author      Denard Springle, denard.springle@gmail.com
* @version     1.0 01/24/2015
* @license     The MIT License (MIT)
*
* The MIT License (MIT)
* Copyright (c) 2015 Denard Springle
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
* to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
* and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
* DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
* OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
component {

	/**
	 * @displayname config
	 * @description MotorSportReg (MSR) API config
	 */
	property name='config' type='struct';


	/**
	 * @displayname init
	 * @description Pass in your MotorSportReg (MSR) API username, password and organization id during component initialization
	 * @param       {String} required  username  Your MotorSportReg (MSR) API username
	 * @param       {String} required  password  Your MotorSportReg (MSR) API password
	 * @param 		{String} required  organizationId  Your MotorSportReg organization id
	 * @returntype  this
	 */
	public function init( required string username, required string password, required string organizationId ){

		this.config.auth = {
			username = trim( arguments.username ),
			password = trim( arguments.password ),
			organizationId = trim( arguments.organizationId )
		};
		this.config.url = 'https://api.motorsportreg.com/rest/';
		this.config.url = "http://apidemo.motorsportreg.com/rest/";

		return this;
	};

	/**
	 * @displayname getCalendars
	 * @description Allows you to query calendars from the API with optional parameters
	 * @param       {String} organizationId  Pass in an organization id to return a calendar of events for a single organization/club
	 * @param 		{String} typeId  Pass in an event type id to return a calendar for a single event type
	 * @param 		{String} venueId  Pass in a venue id to return a calendar of events for a single venue (Laguna Seca, Road Atlanta, etc.)
	 * @param 		{Boolean} archive  default=false  Set to true to include events in the past, only used with organization id
	 * @param 		{String} postalCode Include a five-digit American Zip Code or six-character Canadian Postal Code for geospatial filtering
	 * @param 		{Numeric} radius  default=300  Include a radius around the postal code to search for calendar events, only used with postal code
	 * @param 		{Date} startDate  The starting date to limit results to, only used with authenticated request to /rest/calendars
	 * @param 		{Date} endDate  The ending date to limit results to, only used with authenticated request to /rest/calendars
	 * @param 		{String} format  default=json  One of the following return formats: xml, json, rss, atom or ics (iCalendar)
	 * @returntype  Any
	 */
	public function getCalendars( string organizationId, string typeId, string venueId, boolean archive = false, string postalCode, numeric radius = 300, date startDate, date endDate, format = 'json' ) {

		// set up a data struct
		var data = {}

		// set the method for this REST request
		data.method = 'GET';

		// set the return format of this REST request
		data.format = arguments.format;

		// set if this request requires authentication
		data.authRequest = true;

		// set optional parameter struct
		data.params = {};

		// check for organization id
		if ( !isDefined( 'arguments.organizationId' ) || !len( arguments.organizationId ) ) {

			// no organization id detected, proceed with authenticated calendar request

			// check for venue or type id's 
			if ( !isDefined( 'arguments.typeId' ) || !len( arguments.typeId ) || !isDefined( 'arguments.venueId' ) || !len( arguments.venueId ) ) {
				// no venue or type id's detected, set the REST endpoint for all calendars
				data.endpoint = 'calendars';

			// otherwise, check for type id 				
			} else if( isDefined( 'arguments.typeId' ) && len( arguments.typeId ) ) {
				// type id detected, set the REST endpoint for calendars by type
				data.endpoint = 'calendars/type/' & arguments.typeId;

			// otherwise, check for venue id
			} else if( isDefined( 'arguments.venueId' ) && len( arguments.venueId ) ) {
				// venue id detected, set the REST enfpoint for calendars by venue
				data.endpoint = 'calendar/venue/' & arguments.venueId;
			};

			// ensure we're making a request that supports optional parameters
			if ( !isDefined( 'arguments.venueId' ) && len( arguments.venueId ) ) {

				// check if any optional paramaters are passed, and are valid
				if ( isDefined( 'arguments.postalCode' ) && len( arguments.postalCode ) ) {
					data.params.postalcode = arguments.postalCode;
				};
				
				if ( isNumeric( arguments.radius ) && arguments.radius NEQ 300 ) {
					data.params.radius = arguments.radius;
				};

				if ( (isDefined( 'arguments.startDate' ) && isDate( arguments.startDate ) ) && ( isDefined( 'arguments.endDate') && isDate( arguments.endDate ) ) && ( !isDefined( 'arguments.typeId' ) || !len( arguments.typeId ) ) ) {
					data.params.start = dateFormat( arguments.startDate, 'yyyy-mm-dd' );
					data.params.end = dateFormat( arguments.endDate, 'yyyy-mm-dd' );
				};

			};

		// otherwise
		} else {

			// organization id detected, proceed with unauthenticated calendar request

			// check for type id 
			if ( !isDefined( 'arguments.typeId' ) || !len( arguments.typeId ) ) {
				// no type id detected, set the REST endpoint for organization calendars
				data.endpoint = 'calendars/organization/' & arguments.organizationId;

				// check if the arhive attribute is true 
				if ( isDefined( 'arguments.archive' ) && isBoolean( arguments.archive ) && arguments.archive ) {
					data.params.archive = arguments.archive;
				}

			// otherwise
			} else {
				// type id detected, set the REST endpoint for the organization's calendars by type
				data.endpoint = 'calendars/organization/' & arguments.organizationId & '/type/' & arguments.typeId;

				// check if any optional paramaters are passed, and are valid
				if ( isDefined( 'arguments.postalCode') && len( arguments.postalCode ) ) {
					data.params.postalcode = arguments.postalCode;
				};
				
				if ( isNumeric( arguments.radius ) && arguments.radius NEQ 300 ) {
					data.params.radius = arguments.radius;
				};
			};

			// set the request to be unauthenticated
			data.authRequest = false;

		};

		return doRequest( data );

	};

	/**
	 * @displayname getEvents
	 * @description Allows you to query events from the API with optional parameters
	 * @param 		{String} required  eventId  The event id to make requests for
	 * @param 		{String} method  default=attendees, one of the following event methods: attendees, assignments or segments
	 * @param 		{String} attendeeId  Pass in an attendee id to get the checkin history of the attendee (used with method=attendees only)
	 * @param 		{String} segmentId  Pass in a segment id to see assignment by segment (used with method=segments only)
	 * @param       {String} fields  optional, one of the following field values: questions (used with method=attendees only), team or instructors (used with method=assignments only)
	 * @param 		{String} format  default=json  One of the following return formats: xml or json
	 * @returntype  Any
	 */
	public function getEvents( required string eventId, string method = 'attendees', string attendeeId, string segmentId, string fields, format = 'json' ) {

		// set up a data struct
		var data = {}

		// set the method for this REST request
		data.method = 'GET';

		// set the return format of this REST request
		data.format = arguments.format;

		// set if this request requires authentication
		data.authRequest = true;

		// set optional parameter struct
		data.params = {};

		// check if the segments method is being used
		if ( findNoCase( 'segments', arguments.method ) ) {

			// it is, check if a segment id is being passed in 
			if ( isDefined( 'arguments.segmentId' ) && len( arguments.segmentId ) ) {
				data.endpoint = "events/" & arguments.eventId & "/segments/" & arguments.segmentId & "/assignments";
			} else {
				data.endpoint = "events/" & arguments.eventId & "/segments";
			};

		// otherwise, check if the assignments method is being used 
		} else if ( findNoCase( 'assignments', arguments.method ) ) {

			// it is, set the endpoint to assignments
			data.endpoint = "events/" & arguments.eventId & "/assignments";

			// check if fields=team is requested
			if ( isDefined( 'arguments.fields' ) && findNoCase( 'team', arguments.fields ) ) {
				// it is, set it in the params
				data.params.fields = "team";
			// otherwise, check if fields=instructors is requested
			} else if ( isDefined( 'arguments.fields' ) && findNoCase( 'instructors', arguments.fields ) ) {
				// it is, set it in the params
				data.params.fields = "instructors";
			};

		// otherwise 	
		} else {

			// using default of 'attendees'

			// check if an attendee id is being passed in
			if ( isDefined( 'arguments.attendeeId' ) && len( arguments.attendeeId ) ) {
				// it is, set the endpoint to gather the checkin details for this attendee
				data.endpoint = "events/" & arguments.eventId & "/attendees/" & arguments.attendeeId & "/checkin";
			// otherwise
			} else {
				// set the endpoint to get all attendees for this event
				data.endpoint = "events/" & arguments.eventId & "/attendees";

				// check if fields=questions is requested
				if ( isDefined( 'arguments.fields') && findNoCase( 'questions', arguments.fields ) ) {
					// it is, set it in the params
					data.params.fields = "questions";
				};

			};

		};

		return doRequest( data );

	};

	/**
	* @displayName 	getMembers
	* @description	Allows you to query members from the API
	* @param 		{String} memberId  Pass in the member id to limit results to a specific member (required for mothod=logbook or method=vehicle, optional for method=members)
	* @param 		{String} vehicleId  Pass in the vehicle id to limit results to a specific vehicle (used with method=vehicle only)
	* @param 		{String} method  default=members, one of: members, vehicles or logbook
	* @param 		{String} fields  optional, one of the following field values: questions or history (used with method=members only, requires memberId)
	* @param 		{String} format  default=json  One of the following return formats: xml or json
	* @returntype 	Any
	*/
	public function getMembers( string memberId, string vehicleId, string method = 'members', string fields, string format = 'json') {

		// set up a data struct
		var data = {}

		// set the method for this REST request
		data.method = 'GET';

		// set the return format of this REST request
		data.format = arguments.format;

		// set if this request requires authentication
		data.authRequest = true;

		// set optional parameter struct
		data.params = {};

		// check if the logbook method is being used 
		if ( findNoCase( 'logbook', arguments.method ) ) {

			// check if memberId is defined 
			if ( !isDefined( 'arguments.memberId' ) || !len( arguments.memberId ) ) {
				// member id is not defined, return an error message
				return { success = false, message = "You must supply the member id to get the logbook for that member." };
			// optherwise
			} else {
				// set the endpoint to logbook
				data.endpoint = "members/" & arguments.memberId & "/logbook";
			};

		// otherwise, check if the vehicles method is being used	
		} else if ( findNoCase( 'vehicles', arguments.method ) ) {

			// check if memberId is defined 
			if ( !isDefined( 'arguments.memberId' ) || !len( arguments.memberId ) ) {
				// member id is not defined, return an error message
				return { success = false, message = "You must supply the member id to get the logbook for that member." };
			} else if ( isDefined( 'arguments.vehicleId' ) ) {
				data.endpoint = "members/" & arguments.memberId & "/vehicles/" & arguments.vehicleId;
			} else {
				data.endpoint = "members/" & arguments.memberId & "/vehicles";
			};

		// otherwise	
		} else {

			// using default members method

			// check if memberId is defined 
			if ( isDefined( 'arguments.memberId' ) && len( arguments.memberId ) ) {
				data.endpoint = "members/" & arguments.memberId;

				// check if fields=questions is requested
				if ( isDefined( 'arguments.fields' ) && findNoCase( 'questions', arguments.fields ) ) {
					data.params.fields = "questions";
				} else if( isDefined( 'arguments.fields' ) && findNoCase( 'history', arguments.fields ) ) {
					data.params.fields = "history";
				};
			} else {
				data.endpoint = "members";
			};
		};

		return doRequest( data );

	};

	/**
	* @displayname 	getProfile
	* @description 	Allows you to query profile's and get member id's from the API
	* @param 		{String} required  profileId  The profile id to return
	* @param 		{String} format  default=json  One of the following return formats: xml or json
	* @returntype 	Any
	*/
	public function getProfile( required string profileId, string format = 'json' ) {

		// set up a data struct
		var data = {}

		// set the method for this REST request
		data.method = 'GET';

		// set the return format of this REST request
		data.format = arguments.format;

		// set if this request requires authentication
		data.authRequest = true;

		// set optional parameter struct
		data.params = {};

		// check if the profile id is valid
		if ( !isDefined( 'arguments.profileId' ) || !len( arguments.profileId) ) {
			// profile id is not defined, return an error message
			return { success = false, message = "You must supply the profile id to get the profile for that member." };
		} else {
			data.endpoint = "profiles/" & arguments.profileId;
		};

		return doRequest( data );

	};

	/**
	* @displayname 	getLogbooks
	* @description 	Allows you to query logbooks from the API
	* @param 		{String} logbookId  The logbook id to return
	* @param 		{String} format  default=json  One of the following return formats: xml or json
	* @returntype 	Any
	*/
	public function getLogbooks( string logbookId, string format = 'json' ) {

		// set up a data struct
		var data = {}

		// set the method for this REST request
		data.method = 'GET';

		// set the return format of this REST request
		data.format = arguments.format;

		// set if this request requires authentication
		data.authRequest = true;

		// set optional parameter struct
		data.params = {};

		// check if logbookId is defined
		if ( isDefined( 'arguments.logbookId' ) && len( arguments.logbookId ) ) {
			data.endpoint = "logbooks/" & arguments.logbookIdl
		} else {
			data.endpoint = "logbooks/types";
		};

		return doRequest( data );

	};

	/**
	 * @displayname doRequest
	 * @description Make requests to the MotorSportReg REST API
	 * @param       {Struct} required  data  attributes with optional paramater values to use for this REST request
	 * @returntype  Any
	 */
	private function doRequest( required struct data ) {

		// setup the HTTP service
		var http = new http();
		http.setCharset( 'utf-8' );
		http.setMethod( arguments.data.method );
		http.setUrl( this.config.url & arguments.data.endpoint & '.' & arguments.data.format );

		// check if this is an authenticated request
		if ( arguments.data.authRequest ) {
			// it is, include the username and password
			http.setUsername( this.config.auth.username );
			http.setPassword( this.config.auth.password );	
			// add the required organization id
			http.addParam( type = "header", name = "X-Organization-Id", value = this.config.auth.organizationId );		
		}

		// get the accept formatted string for the requested format 
		var acceptFormat = getFormat( arguments.data.format );
		// add accept for the expected return format
		http.addParam( type = "header", name = "Accept", value = acceptFormat ); 
		// add an encoding accept to gzip the response
		http.addParam( type = "header", name = "Accept-Encoding", value = "gzip,deflate");

		// check for any additional optional parameters required for this request
		if ( !structIsEmpty( arguments.data.params ) ) {
			// there are optional parameters to send, var scope the key
			var param = '';
			// loop through the parameters
			for( param in arguments.data.params ) {
				// and add them to the request
				http.addParam( type = "url", name = "#lCase( param )#", value = arguments.data.params[param] );
			};
		};

		// do the http request
		var result = http.send().getPrefix();

		writeDump( result );
		abort;

		// check if the status code returned is numeric
		if ( isNumeric( result.status_code ) ) {
			// parse the status code for errors
			var status = parseStatusCode( result.status_code );
		} else {
			var status = { success = false, message = result.statuscode };
		}

		// check if the request was successful
		if ( status.success ) {

			// it was, check if the format is json 
			if ( findNoCase( '+json', arguments.data.format ) ) {
				// it is, return the deserialized version of the response
				return deserializeJson( result.filecontent.toString() );
			// otherwise, check if the format is XML
			} else if( findNoCase( '+xml', arguments.data.format ) ) {
				// it is, return the parsed XML version of the response
				return xmlParse( result.filecontent.toString() );
			// otherwise
			} else {
				// just return the response as-is (rss, atom, ical)
				return result.filecontent.toString();
			};
		// otherwise
		} else {
			// an error occured, return the status struct (success(=false), message)
			return status;
		};

	};

	/**
	* @displayname	getFormat
	* @description	I return the Accept header format for the passed in human readable value
	* @param 		{String} required  format  the human readable format value to parse 		
	* @returntype 	Any
	*/
	private function getFormat( required string format ) {

		// set an accept format placeholder
		var acceptFormat = '';

		// switch on the passed in human-readable format
		switch( arguments.format ) {
			case "xml":
				acceptFormat = 'application/vnd.pukkasoft+xml';
				break;
			case "json":
				acceptFormat = 'application/vnd.pukkasoft+json';
				break;
			case "rss":
				acceptFormat = 'application/vnd.pukkasoft+rss';
				break;
			case "atom":
				acceptFormat = 'application/vnd.pukkasoft+atom';
				break;
			case "ical":
				acceptFormat = 'application/vnd.pukkasoft+calendar';
				break;
			default:			
				acceptFormat = 'application/vnd.pukkasoft+json';
		};

		// return the required accept value 
		return acceptFormat;
	};

	/**
	* @displayName 	parseStatusCode
	* @description	I parse the status code returned by the API
	* @param 		{Numeric} required  statusCode  the status code returned from the http request
	* @returntype 	Any
	*/
	private function parseStatusCode( required numeric statusCode ) {

		var status = {};

		switch( arguments.statusCode ) {
			case "401":
				status.success = false;
				status.message = 'Unauthorized (incorrect or missing username and password)';
				break;
			case "403":
				status.success = false;
				status.message = 'Authorized but forbidden request';
				break;
			case "404":
				status.success = false;
				status.message = 'Resource Not Found';
				break;
			case "405":
				status.success = false;
				status.message = 'Method Not Allowed';
				break;
			case "408":
				status.success = false;
				status.message = 'Request Timeout';
				break;
			case "415":
				status.success = false;
				status.message = 'Unsupported Media Type';
				break;
			case "500":
				status.success = false;
				status.message = '[API] Application Error';
				break;
			default:
				status.success = true;
		};

		return status;

	};

}