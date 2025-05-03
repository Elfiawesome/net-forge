class_name Schema extends Node

static func is_valid(data: Array, schema: Array) -> bool:
    if data.size() != schema.size():
        printerr("Schema Check: Data and schema size mismatch")
        return false
    for i in range(data.size()):
        var actual_type := typeof(data[i])
        var expected_type:Variant = schema[i]

        if typeof(expected_type) != TYPE_INT:
            printerr("Schema Check: Schema provided is invalid")
            return false
        if actual_type != expected_type:
            printerr("Schema Check: Expected type %s, got %s" % [expected_type, actual_type])
            return false
    return true