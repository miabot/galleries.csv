require 'rubygems'
require 'csv'
require 'octokit'

require 'faraday-http-cache'
Octokit.middleware = Faraday::Builder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end

$ok = Octokit::Client.new :netrc => true
$ok.login
$sha = $stdin.read.chomp

commit = $ok.repo('kjell/artsmia-galleries').rels[:commits].get(uri: {sha: $sha})
$existing_comments = commit.data.rels[:comments].get.data

def commit_comment!(body, file, position)
  if comment = $existing_comments.select {|c| c.path == file && c.position == position }.shift
    $ok.update_commit_comment('kjell/artsmia-galleries', comment.id, body)
  else
    $ok.create_commit_comment('kjell/artsmia-galleries', $sha, body, file, nil, position)
  end
end

def comment_body(id, name)
  "[![#{name}](//api.artsmia.org/images/#{id}/600/medium.jpg)](//collections.artsmia.org/?page=simple&id=#{id})"
end

commit.data.files.each do |file|
  puts file.filename
  file.patch.lines.map.with_index do |line, index|
    if _csv = line[/^[-+](\d.*)/, 1] # it's an addition or deletion and has an object id
      csv = CSV.parse(_csv).shift
      csv << index
    end
  end.compact.group_by {|id, _| id}.each do |id, rows|
    row = rows.last # if it was both removed and added, only post the image once
    p rows.last
    commit_comment!(comment_body(id, row[1]), file.filename, row.last)
  end
  puts "\n\n"
end
