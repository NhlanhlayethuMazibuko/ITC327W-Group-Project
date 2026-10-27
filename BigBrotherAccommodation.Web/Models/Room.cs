using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BigBrotherAccommodation.Web.Models
{
    [Table("room")]
    public class Room : BaseModel
    {
        [PrimaryKey("room_id")]
        public Guid Id { get; set; }

        [Column("room_name")]
        public string Name { get; set; } = "";

        [Column("room_type")]
        public string RoomType { get; set; } = "";

        [Column("price")]
        public decimal Price { get; set; }

        [Column("availability_status")]
        public bool IsAvailable { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("wifi")]
        public bool Wifi { get; set; }

        [Column("laundry")]
        public bool Laundry { get; set; }

        [Column("security")]
        public bool Security { get; set; }

        [Column("shuttle")]
        public bool Shuttle { get; set; }

        [Column("furniture")]
        public bool Furniture { get; set; }
    }
}