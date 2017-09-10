defmodule API.Error do
  @enforce_keys [:http_code, :code, :message]
  defstruct [:http_code, :code, :message]

  @type t :: %API.Error {
    http_code: String.t,
    code:      String.t,
    message:   String.t
  }

  # @spec build_error(String.t, String.t, String.t) :: API.Error.t
  defp build_error(http_code, code, message) do
    %API.Error{http_code: http_code, code: code, message: message}
  end

  @spec make(atom) :: API.Error.t
  def make(:authorization_required) do
    build_error(401,
        "AuthorizationRequired",
        "Authorization Required")
  end

  def make(:validation_failure) do
    build_error(400,
        "ValidationError",
        "Validation Failure")
  end

  def make(:invalid_argument) do
    build_error(400,
        "InvalidArgument",
        "Specification Mismatch")
  end

  def make(:not_found) do
    build_error(404,
        "NotFound",
        "Resource Not Found")
  end

  def make(:request_timeout) do
    build_error(408,
        "RequestTimeout",
        "Please Try Again.")
  end

  def make(:request_too_large) do
    build_error(413,
        "RequestEntityTooLarge",
        "Please send < 1 MB.")
  end

  def make(:operation_not_implemented) do
    build_error(500,
        "InternalServerError",
        "Operation Not Implemented.")
  end

  def make(:service_unavailable) do
    build_error(503,
        "ServiceUnavailable",
        "Please try again later.")
  end

  @spec format(atom) :: iodata
  def format(atom) when is_atom(atom) do
    error = make(atom)
    JSON.encode!(%{
      type: error.code,
      message: error.message})
  end

  @spec format(API.Error.t) :: iodata
  def format(%API.Error{} = error) do
    %{type: error.code,
      message: error.message}
  end
end
