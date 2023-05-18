class IglesiasModel {
  int? success;
  List<DataIglesias>? iglesias;

  IglesiasModel({this.success, this.iglesias});

  IglesiasModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['iglesias'] != null) {
      iglesias = <DataIglesias>[];
      json['iglesias'].forEach((v) {
        iglesias!.add(DataIglesias.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (iglesias != null) {
      data['iglesias'] = iglesias!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataIglesias {
  int? id;
  int? idIglesia;
  String? titulo;
  String? direccion;
  String? comunidad;
  String? provincia;
  String? ciudad;
  String? distrito;
  String? region;
  String? zona;
  String? descripcion;
  String? valoracion;
  double? latitud;
  double? longitud;
  String? telefono;
  String? web;
  String? timestamp;
  int? activo;
  int? idPastor;
  String? nombre;
  String? apellidos;
  String? telefonoFijo;
  String? telefonoMovil;
  String? email;
  String? socialMedia;

  DataIglesias(
      {this.id,
      this.idIglesia,
      this.titulo,
      this.direccion,
      this.comunidad,
      this.provincia,
      this.ciudad,
      this.distrito,
      this.region,
      this.zona,
      this.descripcion,
      this.valoracion,
      this.latitud,
      this.longitud,
      this.telefono,
      this.web,
      this.timestamp,
      this.activo,
      this.idPastor,
      this.nombre,
      this.apellidos,
      this.telefonoFijo,
      this.telefonoMovil,
      this.email,
      this.socialMedia});

  DataIglesias.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idIglesia = json['idIglesia'];
    titulo = json['titulo'];
    direccion = json['direccion'];
    comunidad = json['comunidad'];
    provincia = json['provincia'];
    ciudad = json['ciudad'];
    distrito = json['distrito'];
    region = json['region'];
    zona = json['zona'];
    descripcion = json['descripcion'];
    valoracion = json['valoracion'];
    latitud = json['latitud'];
    longitud = json['longitud'];
    telefono = json['telefono'];
    web = json['web'];
    timestamp = json['timestamp'];
    activo = json['activo'];
    idPastor = json['idPastor'];
    nombre = json['nombre'];
    apellidos = json['apellidos'];
    telefonoFijo = json['telefono_fijo'];
    telefonoMovil = json['telefono_movil'];
    email = json['email'];
    socialMedia = json['socialMedia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['idIglesia'] = idIglesia;
    data['titulo'] = titulo;
    data['direccion'] = direccion;
    data['comunidad'] = comunidad;
    data['provincia'] = provincia;
    data['ciudad'] = ciudad;
    data['distrito'] = distrito;
    data['region'] = region;
    data['zona'] = zona;
    data['descripcion'] = descripcion;
    data['valoracion'] = valoracion;
    data['latitud'] = latitud;
    data['longitud'] = longitud;
    data['telefono'] = telefono;
    data['web'] = web;
    data['timestamp'] = timestamp;
    data['activo'] = activo;
    data['idPastor'] = idPastor;
    data['nombre'] = nombre;
    data['apellidos'] = apellidos;
    data['telefono_fijo'] = telefonoFijo;
    data['telefono_movil'] = telefonoMovil;
    data['email'] = email;
    data['socialMedia'] = socialMedia;
    return data;
  }
}
