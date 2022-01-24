require 'formula'

class DockerComposeOroplatform < Formula
  url "https://github.com/digitalspacestdio/homebrew-brewtools.git", :using => :git
  version "0.1.0"
  revision 1

  def install
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"brew-build-recursive"
    bin.write_exec_script libexec/"brew-clean-build-recursive"
    bin.write_exec_script libexec/"brew-list-build-deps"
    bin.write_exec_script libexec/"brew-list-build-only-deps"
  end

  def caveats
    s = <<~EOS
      linuxbrew-tools was installed
    EOS
    s
  end
end
