module Newegg
  class Api

    attr_accessor :conn, :_stores, :_categories

    def initialize
      self._stores = []
      self._categories = []
    end

    #
    # retrieve an active connection or establish a new connection
    #
    # @ returns [Faraday::Connection] conn to the web service
    #
    def connection
      self.conn ||= Faraday.new(:url => 'http://www.ows.newegg.com') do |faraday|
        faraday.request :url_encoded            # form-encode POST params
        faraday.response :logger                # log requests to STDOUT
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end      
    end
    
    #
    # retrieve and populate a list of available stores
    #
    def stores
      return self._stores if not self._stores.empty?
      response = api_get("Stores.egg")
      stores = JSON.parse(response.body)
      stores.each do |store|
        self._stores <<  Newegg::Store.new(store['Title'], store['StoreDepa'], store['StoreID'], store['ShowSeeAllDeals'])
      end
      self._stores
    end
    
    #
    # retrieve and populate list of categories for a given store_id
    #
    def categories(store_id)
      store_index = self._stores.index{ |store| store.store_id == store_id.to_i }

      response = api_get("Stores.egg", "Categories", store_id)
      categories = JSON.parse(response.body)
      categories.each do |category|
        self._categories << Newegg::Category.new(category['Description'], category['CategoryType'], category['CategoryID'],
                                                 category['StoreID'], category['ShowSeeAllDeals'], category['NodeId'])
      end
      
      self._stores[store_index].categories = self._categories
    end  
    
    private
    
    #
    # GET: {controller}/{action}/{id}/
    #
    # @param [String] controller
    # @param [optional, String] action
    # @param [optional, String] id
    #
    def api_get(controller, action = nil, id = nil)
      uri = String.new

      if action && id
        uri = "/#{controller}/#{action}/#{id}"
      else
        uri = "/#{controller}/"
      end

      response = self.connection.get(uri)
      
      case code = response.status.to_i
      when 400..499
        raise(Newegg::NeweggClientError, "error, #{code}: #{response.inspect}")
      when 500..599
        raise(Newegg::NeweggServerError, "error, #{code}: #{response.inspect}")
      else
        response
      end
    end

    #
    # POST: {controller}/{action}/
    #
    # @param [String] controller
    # @param [String] action
    # @param [Hash] opts
    #
    def api_post(controller, action, opts={})
      response = self.connection.post do |request|
        request.url "/#{controller}/#{action}/"
        request.headers['Content-Type'] = 'application/json'
        request.headers['Accept']       = 'application/json'
        request.headers['Api-Version']  = '2.2'
        request.body = opts.to_json
      end

      case code = response.status.to_i
      when 400..499
        raise(Newegg::NeweggClientError, "error, #{code}: #{response.inspect}")
      when 500..599
        raise(Newegg::NeweggServerError, "error, #{code}: #{response.inspect}")
      else
        response
      end
    end
    
  end
end