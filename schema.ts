
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      fcm_tokens: {
        Row: {
          created_at: string
          device_type: string | null
          id: string
          token: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          device_type?: string | null
          id?: string
          token: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          device_type?: string | null
          id?: string
          token?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      fortune_notifications: {
        Row: {
          created_at: string | null
          fortune_id: string | null
          id: number
          is_read: boolean | null
          message: string
          read_at: string | null
          title: string
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          fortune_id?: string | null
          id?: number
          is_read?: boolean | null
          message: string
          read_at?: string | null
          title: string
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          fortune_id?: string | null
          id?: number
          is_read?: boolean | null
          message?: string
          read_at?: string | null
          title?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fortune_notifications_fortune_id_fkey"
            columns: ["fortune_id"]
            isOneToOne: false
            referencedRelation: "fortune_readings"
            referencedColumns: ["uuid"]
          },
        ]
      }
      fortune_readings: {
        Row: {
          completed_at: string | null
          created_at: string
          id: number
          image_url: string | null
          interpretation: string | null
          is_premium: boolean
          status: string
          user_id: string
          uuid: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string
          id?: number
          image_url?: string | null
          interpretation?: string | null
          is_premium?: boolean
          status?: string
          user_id?: string
          uuid?: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string
          id?: number
          image_url?: string | null
          interpretation?: string | null
          is_premium?: boolean
          status?: string
          user_id?: string
          uuid?: string
        }
        Relationships: []
      }
      horoscopes: {
        Row: {
          created_at: string
          daily_horoscope: string | null
          date: string | null
          id: number
          is_premium: boolean | null
          luck_color: string | null
          luck_number: string | null
          scores: Json | null
          sign: string | null
        }
        Insert: {
          created_at?: string
          daily_horoscope?: string | null
          date?: string | null
          id?: number
          is_premium?: boolean | null
          luck_color?: string | null
          luck_number?: string | null
          scores?: Json | null
          sign?: string | null
        }
        Update: {
          created_at?: string
          daily_horoscope?: string | null
          date?: string | null
          id?: number
          is_premium?: boolean | null
          luck_color?: string | null
          luck_number?: string | null
          scores?: Json | null
          sign?: string | null
        }
        Relationships: []
      }
      notification_settings: {
        Row: {
          coffee_reminder_enabled: boolean
          coffee_reminder_time: string[]
          created_at: string
          horoscope_reminder_enabled: boolean
          horoscope_reminder_time: string
          id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          coffee_reminder_enabled?: boolean
          coffee_reminder_time?: string[]
          created_at?: string
          horoscope_reminder_enabled?: boolean
          horoscope_reminder_time?: string
          id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          coffee_reminder_enabled?: boolean
          coffee_reminder_time?: string[]
          created_at?: string
          horoscope_reminder_enabled?: boolean
          horoscope_reminder_time?: string
          id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      notifications: {
        Row: {
          body: string
          created_at: string | null
          id: string
          is_read: boolean | null
          is_sent: boolean | null
          scheduled_for: string | null
          scheduled_time: string | null
          title: string
          type: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          body: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          is_sent?: boolean | null
          scheduled_for?: string | null
          scheduled_time?: string | null
          title: string
          type: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          body?: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          is_sent?: boolean | null
          scheduled_for?: string | null
          scheduled_time?: string | null
          title?: string
          type?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          birth_date: string
          created_at: string | null
          email: string
          first_name: string
          id: string
          is_active: boolean | null
          last_name: string
          last_sign_in: string | null
        }
        Insert: {
          birth_date: string
          created_at?: string | null
          email: string
          first_name: string
          id: string
          is_active?: boolean | null
          last_name: string
          last_sign_in?: string | null
        }
        Update: {
          birth_date?: string
          created_at?: string | null
          email?: string
          first_name?: string
          id?: string
          is_active?: boolean | null
          last_name?: string
          last_sign_in?: string | null
        }
        Relationships: []
      }
      user_fcm_tokens: {
        Row: {
          created_at: string | null
          id: string
          token: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          token: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          token?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      users: {
        Row: {
          created_at: string
          email: string
          id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          email: string
          id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          email?: string
          id?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      public_profiles: {
        Row: {
          first_name: string | null
          id: string | null
          last_name: string | null
        }
        Insert: {
          first_name?: string | null
          id?: string | null
          last_name?: string | null
        }
        Update: {
          first_name?: string | null
          id?: string | null
          last_name?: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      bytea_to_text: {
        Args: {
          data: string
        }
        Returns: string
      }
      check_scheduled_notifications: {
        Args: {
          input_user_id: string
          is_test?: boolean
        }
        Returns: Json
      }
      format_headers: {
        Args: {
          headers: unknown[]
        }
        Returns: string[]
      }
      http: {
        Args: {
          request: unknown
        }
        Returns: Database["public"]["CompositeTypes"]["http_response"]
      }
      http_delete:
        | {
            Args: {
              uri: string
            }
            Returns: Database["public"]["CompositeTypes"]["http_response"]
          }
        | {
            Args: {
              uri: string
              content: string
              content_type: string
            }
            Returns: Database["public"]["CompositeTypes"]["http_response"]
          }
      http_get:
        | {
            Args: {
              uri: string
            }
            Returns: Database["public"]["CompositeTypes"]["http_response"]
          }
        | {
            Args: {
              uri: string
              data: Json
            }
            Returns: Database["public"]["CompositeTypes"]["http_response"]
          }
      http_head: {
        Args: {
          uri: string
        }
        Returns: Database["public"]["CompositeTypes"]["http_response"]
      }
      http_header: {
        Args: {
          field: string
          value: string
        }
        Returns: unknown
      }
      http_list_curlopt: {
        Args: Record<PropertyKey, never>
        Returns: {
          curlopt: string
          value: string
        }[]
      }
      http_patch: {
        Args: {
          uri: string
          content: string
          content_type: string
        }
        Returns: Database["public"]["CompositeTypes"]["http_response"]
      }
      http_post:
        | {
            Args: {
              post_url: string
              post_body: string
              post_headers?: unknown[]
            }
            Returns: {
              status: number
              content: string
              headers: string[]
            }[]
          }
        | {
            Args: {
              uri: string
              content: string
              content_type: string
            }
            Returns: Database["public"]["CompositeTypes"]["http_response"]
          }
        | {
            Args: {
              uri: string
              data: Json
            }
            Returns: Database["public"]["CompositeTypes"]["http_response"]
          }
      http_put: {
        Args: {
          uri: string
          content: string
          content_type: string
        }
        Returns: Database["public"]["CompositeTypes"]["http_response"]
      }
      http_request: {
        Args: {
          http_method: string
          http_url: string
          http_headers?: string[]
          http_body?: string
        }
        Returns: {
          status: number
          content: string
          headers: string[]
        }[]
      }
      http_reset_curlopt: {
        Args: Record<PropertyKey, never>
        Returns: boolean
      }
      http_set_curlopt: {
        Args: {
          curlopt: string
          value: string
        }
        Returns: boolean
      }
      send_push_notification: {
        Args: {
          p_token: string
          p_title: string
          p_body: string
          p_type: string
          p_notification_id?: string
        }
        Returns: Json
      }
      test_http_request:
        | {
            Args: {
              test_user_id: string
              is_test?: boolean
            }
            Returns: {
              status: number
              content: string
              headers: string[]
            }[]
          }
        | {
            Args: {
              test_user_id: string
              is_test?: boolean
              api_key?: string
            }
            Returns: {
              status: number
              content: string
              headers: string[]
            }[]
          }
      text_to_bytea: {
        Args: {
          data: string
        }
        Returns: string
      }
      urlencode:
        | {
            Args: {
              data: Json
            }
            Returns: string
          }
        | {
            Args: {
              string: string
            }
            Returns: string
          }
        | {
            Args: {
              string: string
            }
            Returns: string
          }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      http_header: {
        field: string | null
        value: string | null
      }
      http_request: {
        method: unknown | null
        uri: string | null
        headers: unknown[] | null
        content_type: string | null
        content: string | null
      }
      http_response: {
        status: number | null
        content_type: string | null
        headers: unknown[] | null
        content: string | null
      }
    }
  }
}

type PublicSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  PublicTableNameOrOptions extends
    | keyof (PublicSchema["Tables"] & PublicSchema["Views"])
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
        Database[PublicTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
      Database[PublicTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : PublicTableNameOrOptions extends keyof (PublicSchema["Tables"] &
        PublicSchema["Views"])
    ? (PublicSchema["Tables"] &
        PublicSchema["Views"])[PublicTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  PublicEnumNameOrOptions extends
    | keyof PublicSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends PublicEnumNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = PublicEnumNameOrOptions extends { schema: keyof Database }
  ? Database[PublicEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : PublicEnumNameOrOptions extends keyof PublicSchema["Enums"]
    ? PublicSchema["Enums"][PublicEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof PublicSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof PublicSchema["CompositeTypes"]
    ? PublicSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never
