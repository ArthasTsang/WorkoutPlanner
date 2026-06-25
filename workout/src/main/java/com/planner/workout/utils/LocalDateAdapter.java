package com.planner.workout.utils;

import java.io.IOException;
import java.time.LocalDate;

import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;

public class LocalDateAdapter extends TypeAdapter<LocalDate>{

    @Override
    public void write(JsonWriter writer, LocalDate obj) throws IOException {
        if (obj == null) {
            writer.nullValue();
            return;
        }
        // Custom serialization logic:
        // writer.beginObject();
        writer.value(obj.toString());
        // writer.endObject();
    }

    @Override
    public LocalDate read(JsonReader reader) throws IOException {
        // Custom deserialization logic:
        // ... (implement reading from reader to create MyClass instance)
        return LocalDate.parse(reader.nextString()); // Example
    }

}
