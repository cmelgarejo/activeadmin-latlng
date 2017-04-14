module ActiveAdmin
  module Views
    class ActiveAdminForm
      def latlng **args
        class_name = form_builder.object.class.model_name.element
        lang   = args[:lang]   || 'en'
        map    = args[:map]    || :google
        id_lat = args[:id_lat] || "#{class_name}_lat"
        id_lng = args[:id_lng] || "#{class_name}_lng"
        start_lat = args[:start_lng] || 0.0
        start_lng = args[:start_lng] || 0.0
        height = args[:height] || 400
        loading_map = args[:loading_map].nil? ? true : args[:loading_map]

        case map
        when :yandex
          insert_tag(YandexMapProxy, form_builder, lang, id_lat, id_lng, start_lat, start_lng, height, loading_map)
        when :google
          insert_tag(GoogleMapProxy, form_builder, lang, id_lat, id_lng, start_lat, start_lng, height, loading_map)
        else
          insert_tag(GoogleMapProxy, form_builder, lang, id_lat, id_lng, start_lat, start_lng, height, loading_map)
        end
      end
    end

    class LatlngProxy < FormtasticProxy
      def build(form_builder, *args, &block)
        @lang, @id_lat, @id_lng, @start_lat, @start_lng, @height, @loading_map = *args
      end
    end

    class GoogleMapProxy < LatlngProxy
      def to_s
        loading_map_code = @loading_map ? "<script src=\"https://maps.googleapis.com/maps/api/js?language=#{@lang}&callback=googleMapObject.init\" async defer></script>" : ''
        "<li>" \
        "#{loading_map_code}" \
        "<div id=\"google_map\" style=\"height: #{@height}px\"></div>" \
        "<script>
          var _lat = #{@start_lat}, _lng = #{@start_lng};
          function __getGeoLocation() {
              if (navigator.geolocation)
                  navigator.geolocation.getCurrentPosition(_successGeoLocation);
              else
                  console.log(\"Geolocation is not supported by this browser.\");
          }
          function _successGeoLocation(pos) {
            if(googleMapObject.coords.lat == _lat && googleMapObject.coords.lng == _lng) {
              googleMapObject.coords.lat = pos.coords.latitude;
              googleMapObject.coords.lng = pos.coords.longitude;
              googleMapObject.marker.setPosition(googleMapObject.coords);
              $(\"##{@id_lat}\").val( googleMapObject.coords.lat.toFixed(10) );
              $(\"##{@id_lng}\").val( googleMapObject.coords.lng.toFixed(10) );
            }
          }

          var googleMapObject = {
            coords: null,
            map: null,
            marker: null,

            getCoordinates: function() {
              return {
                lat: parseFloat($(\"##{@id_lat}\").val()) || _lat,
                lng: parseFloat($(\"##{@id_lng}\").val()) || _lng
              };
            },

            saveCoordinates: function() {
              $(\"##{@id_lat}\").val( googleMapObject.coords.lat.toFixed(10) );
              $(\"##{@id_lng}\").val( googleMapObject.coords.lng.toFixed(10) );
            },

            init: function() {
              __getGeoLocation();
              googleMapObject.coords = googleMapObject.getCoordinates();
              googleMapObject.saveCoordinates();

              googleMapObject.map = new google.maps.Map(document.getElementById('google_map'), {
                center: googleMapObject.coords,
                zoom: 12
              });
              
              var latLngCoord = new google.maps.LatLng(googleMapObject.coords.lat, googleMapObject.coords.lng);
              googleMapObject.marker = new google.maps.Marker({
                position: latLngCoord,
                map: googleMapObject.map,
                draggable: true
              });
              googleMapObject.map.addListener('click', function(e) {
                googleMapObject.coords = { lat: e.latLng.lat(), lng: e.latLng.lng() };
                googleMapObject.saveCoordinates();
                googleMapObject.marker.setPosition(googleMapObject.coords);
              });
              googleMapObject.marker.addListener('drag', function(e) {
                googleMapObject.coords = { lat: e.latLng.lat(), lng: e.latLng.lng() };
                googleMapObject.saveCoordinates();
              });
            }
          }
        </script>" \
        "</li>"
      end
    end

    class YandexMapProxy < LatlngProxy
      def to_s
        loading_map_code = @loading_map ? "<script src=\"https://api-maps.yandex.ru/2.1/?lang=#{@lang}&load=Map,Placemark\" type=\"text/javascript\"></script>" : ''
        "<li>" \
        "#{loading_map_code}" \
        "<div id=\"yandex_map\" style=\"height: #{@height}px\"></div>" \
        "<script type=\"text/javascript\">
          var _lat = #{@start_lat}, _lng = #{@start_lng};
          function __getGeoLocation() {
              if (navigator.geolocation)
                  navigator.geolocation.getCurrentPosition(_successGeoLocation);
              else
                  console.log(\"Geolocation is not supported by this browser.\");
          }
          function _successGeoLocation(pos) {
            if(yandexMapObject.coords[0] == _lat && yandexMapObject.coords[1] == _lng) {
              yandexMapObject.coords = [pos.coords.latitude, pos.coords.longitude];
              yandexMapObject.placemark.geometry.setCoordinates(yandexMapObject.coords);
              yandexMapObject.map.setCenter(yandexMapObject.coords);
              $(\"##{@id_lat}\").val( yandexMapObject.coords[0].toFixed(10) );
              $(\"##{@id_lng}\").val( yandexMapObject.coords[1].toFixed(10) );
            }
          }
          var yandexMapObject = {
            coords: null,
            map: null,
            placemark: null,

            getCoordinates: function() {
              return [
                parseFloat($(\"##{@id_lat}\").val()) || _lat,
                parseFloat($(\"##{@id_lng}\").val()) || _lng,
              ];
            },

            saveCoordinates: function() {
              $(\"##{@id_lat}\").val( yandexMapObject.coords[0].toFixed(10) );
              $(\"##{@id_lng}\").val( yandexMapObject.coords[1].toFixed(10) );
            },

            init: function() {
              __getGeoLocation();
              yandexMapObject.coords = yandexMapObject.getCoordinates();
              yandexMapObject.saveCoordinates();

              yandexMapObject.map = new ymaps.Map(\"yandex_map\", {
                  center: yandexMapObject.coords,
                  zoom: 12
              });

              yandexMapObject.placemark = new ymaps.Placemark( yandexMapObject.coords, {}, { preset: \"twirl#redIcon\", draggable: true } );
              yandexMapObject.map.geoObjects.add(yandexMapObject.placemark);

              yandexMapObject.placemark.events.add(\"dragend\", function (e) {      
                yandexMapObject.coords = this.geometry.getCoordinates();
                yandexMapObject.saveCoordinates();
              }, yandexMapObject.placemark);

              yandexMapObject.map.events.add(\"click\", function (e) {        
                yandexMapObject.coords = e.get(\"coords\");
                yandexMapObject.saveCoordinates();
                yandexMapObject.placemark.geometry.setCoordinates(yandexMapObject.coords);
              });
            }
          }

          ymaps.ready(yandexMapObject.init);
        </script>" \
        "</li>"
      end
    end
  end
end
