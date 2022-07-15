import NextAuth from "next-auth"
import GithubProvider from "next-auth/providers/github"

import { query as q } from "faunadb"
import { fauna } from "../../../services/fauna"
import { JWT } from "next-auth/jwt"

export default NextAuth({
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    }),
  ],
  jwt: {
    async encode(params: {
      token: JWT
      secret: string
      maxAge: number
    }): Promise<string> {
      // return a custom encoded JWT string
      return process.env.SIGNING_KEY
    },
    async decode(params: {
      token: string
      secret: string
    }): Promise<JWT | null> {
      // return a `JWT` object, or `null` if decoding failed
      return {}
    },
  },
  callbacks: {
    async signIn(params) {
      try {
        await fauna.query(
          q.Create(
            q.Collection('users')
            , { data: { email: params.user.email } }
          )
        )
        return true;
      } catch {
        return true;
      }
    },
  },
})