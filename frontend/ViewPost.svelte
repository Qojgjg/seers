<script lang="ts">
  import { onMount } from "svelte"
  import Fa from "svelte-fa"
  import { Link } from "svelte-navigator"
  import { faComment, faHeart } from "@fortawesome/free-regular-svg-icons"
  import { faRetweet } from "@fortawesome/free-solid-svg-icons"

  export let auth
  export let principal
  export let signIn
  export let id

  let user = null

  let response = null
  let errorRefresh = ""
  let isGetting = false
  let post = null

  function parseTwitterDate(tdate) {
    var system_date = new Date(tdate)
    var user_date = new Date()

    var diff = Math.floor((Number(user_date) - Number(system_date)) / 1000)
    if (diff <= 1) {
      return "just now"
    }
    if (diff < 20) {
      return diff + " seconds ago"
    }
    if (diff < 40) {
      return "half a minute ago"
    }
    if (diff < 60) {
      return "less than a minute ago"
    }
    if (diff <= 90) {
      return "one minute ago"
    }
    if (diff <= 3540) {
      return Math.round(diff / 60) + " minutes ago"
    }
    if (diff <= 5400) {
      return "1 hour ago"
    }
    if (diff <= 86400) {
      return Math.round(diff / 3600) + " hours ago"
    }
    if (diff <= 129600) {
      return "1 day ago"
    }
    if (diff < 604800) {
      return Math.round(diff / 86400) + " days ago"
    }
    if (diff <= 777600) {
      return "1 week ago"
    }
    return "on " + system_date
  }

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const getPost = async () => {
    post = await $auth.actor.getPost(principal, Number(id))
    if ("ok" in post) {
      post = post["ok"]
    } else {
      console.log(post["err"])
    }
    console.log(post)
  }

  onMount(getPost)
</script>

<div style="justify-content: center; display: flex;width: 100%">
  <div class="rowUser">
    <div
      style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 0px solid grey"
    >
      <div style="padding: 5px; margin: 5px; height: 100%">
        <a href={`/profile/${post?.author.principal}`}>
          <img
            src={post?.author.picture}
            alt="avatar"
            style="width: 50px; object-fit: cover; border-radius: 50%"
          />
        </a>
      </div>
      <div style="flex-grow: 1; justify-content: start; text-align:start">
        <div style="display:flex; gap: 5px;">
          <div>
            <a href={`/profile/${post?.author.principal}`}
              >{post?.author.name}</a
            >
          </div>
          <div style="color:grey">
            <a href={`/profile/${post?.author.principal}`} style="color:grey">
              @{post?.author.handle}
            </a>
          </div>
          <div style="color:grey">
            - {parseTwitterDate(parseInt(post?.createdAt) / 1_000_000)}
          </div>
        </div>
        <Link
          to={`/profile/${post?.author.principal}/post/${post?.id}`}
          style="width: 100%"
        >
          <div style="width: 100%; text-align:start; padding: 5px 0px">
            {post?.content}
          </div>
        </Link>
        <div
          style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
        >
          <div style="width: 50px; display:flex; gap: 15px">
            <div><Fa icon={faComment} /></div>
            <div>0</div>
          </div>
          <div style="width: 50px; display:flex; gap: 15px">
            <div><Fa icon={faRetweet} /></div>
            <div>0</div>
          </div>
          <div style="width: 50px; display:flex; gap: 15px">
            <div><Fa icon={faHeart} /></div>
            <div>0</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<style global>
  .rowUser {
    display: flex;
    flex-wrap: wrap;
    padding: 1em;
    justify-content: start;
    min-width: 200px;
    max-width: 800px;
    width: 80%;
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);

    border-radius: 16px;
    justify-content: center;
    color: rgb(255, 255, 255);
  }
</style>
