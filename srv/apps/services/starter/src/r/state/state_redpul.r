#' get_redpul_state
#' @export get_redpul_state
get_redpul_state <- function() {
  redisConnect(host = Sys.getenv("REDIS_HOST"))
  on.exit(redisClose())
  fromJSON(redisGet("redpul_state")[[1]])
}
