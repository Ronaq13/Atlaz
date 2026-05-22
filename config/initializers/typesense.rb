TYPESENSE_CLIENT = Typesense::Client.new(
  nodes: [
    {
      host:     Rails.application.credentials.dig(:typesense, :host) || "localhost",
      port:     Rails.application.credentials.dig(:typesense, :port) || 8108,
      protocol: Rails.application.credentials.dig(:typesense, :protocol) || "http"
    }
  ],
  api_key:             Rails.application.credentials.dig(:typesense, :api_key) || "xyz",
  connection_timeout_seconds: 5
)

# Schema for the hotels collection.
# Re-used by both the collection creation task and the index sync job.
HOTELS_COLLECTION_SCHEMA = {
  name:                 "hotels",
  enable_nested_fields: false,
  fields: [
    { name: "id",            type: "string" },
    { name: "name",          type: "string" },
    { name: "description",   type: "string", optional: true },
    { name: "address",       type: "string", optional: true },
    { name: "slug",          type: "string", optional: true },
    { name: "hero_image_url",type: "string", optional: true, index: false },
    { name: "class_rating",  type: "int32",  optional: true, facet: true },
    { name: "customer_rating", type: "int32", optional: true, facet: true },
    { name: "amenities",     type: "string[]", optional: true, facet: true },
    { name: "destination_id",type: "int64",  facet: true },
    { name: "state",         type: "string", facet: true },
    { name: "lat",           type: "float",  optional: true },
    { name: "long",          type: "float",  optional: true },
    # Rate buckets — 0 means no rate available for that window
    { name: "rate_1m",       type: "float",  optional: true, facet: false },
    { name: "rate_3m",       type: "float",  optional: true, facet: false },
    { name: "rate_6m",       type: "float",  optional: true, facet: false },
    { name: "rate_9m",       type: "float",  optional: true, facet: false },
    { name: "currency",      type: "string", optional: true }
  ],
  default_sorting_field: ""
}.freeze
