# ActiveadminLatlng

Active Admin latitude and longitude plugin

![alt tag](https://raw.githubusercontent.com/forsaken1/activeadmin-latlng/master/aa_latlng.png)



## Getting started

```ruby
gem 'activeadmin_latlng'
```

```ruby
form do |f|
  f.inputs do
    f.input :lat
    f.input :lng
    f.latlng # add this
  end
  f.actions
end
```



## Settings

* `lang` - language, `en` by default.

* `map` - map provider, `google` by default. Available: `google`, `yandex`.

* `id_lat` and `id_lng` - identificator of latitude and longitude inputs. `<model_name>_lat` and `<model_name>_lng` by default.

* `height` - map height in pixels, `400` by default.

* `loading_map` - loading map library. `true` by default. Set to `false`, if map loaded in other place.

* `api_key` - set the API KEY for the Google Maps option

### Example

```ruby
form do |f|
  f.inputs do
    f.input :lat
    f.input :lng
    f.latlng lang: :ru, map: :google, height: 500, loading_map: false, api_key: T3GRGE$U5rydr5YrhdRYehrEdrhey5h_ge
  end
  f.actions
end
```



## Contributors

Alexey Krylov
Christian Melgarejo

## License

MIT License. Copyright 2016 Alexey Krylov
MIT License. Copyright 2017 Christian Melgarejo
