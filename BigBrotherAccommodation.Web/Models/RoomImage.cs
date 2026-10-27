using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BigBrotherAccommodation.Web.Models
{
    [Table("room_image")]
    public class RoomImage : BaseModel
    {
        [PrimaryKey("image_id")]
        public Guid Id { get; set; }

        [Column("room_id")]
        public Guid RoomId { get; set; }

        [Column("image_path")]
        public string Image { get; set; } = "";
    }
}