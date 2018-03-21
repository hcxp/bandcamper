class AlbumRepository < Hanami::Repository
  def find_by_uids(uids)
    albums
      .where(uid: uids)
  end

  def count
    albums.count
  end

  def delete_by_uids(uids)
    albums.where(uid: uids).delete
  end
end
