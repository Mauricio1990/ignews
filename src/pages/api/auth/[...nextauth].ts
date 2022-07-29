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
  callbacks: {
    async signIn(params) {
      try {
        await fauna.query(
          q.If(
            q.Not(
              q.Exists(
                q.Match(
                  q.Index('user_by_email'),
                  q.Casefold(params.user.email)
                )
              )
            ),
            q.Create(
              q.Collection('users')
              , { data: { email: params.user.email } }
            ),
            q.Exists(
              q.Match(
                q.Index('user_by_email'),
                q.Casefold(params.user.email)
              )
            )
          )
        )
        return true;
      } catch {
        return false;
      }
    },
  },
})