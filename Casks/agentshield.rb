cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1865"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1865/agentshield_0.2.1865_darwin_amd64.tar.gz"
      sha256 "2fef443a3bcf947b30737b84cdba03a681932022c0aa2297b8dc32b55426eafe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1865/agentshield_0.2.1865_darwin_arm64.tar.gz"
      sha256 "1a0dd7878fa47c2bfb00d86b78a7b54d0afdfd111227f17f94a5d0df7d6cb89d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1865/agentshield_0.2.1865_linux_amd64.tar.gz"
      sha256 "7e351050fcb9e3ec752536188e017ce1bf48a814af741302fb2ee8d2806f8ac4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1865/agentshield_0.2.1865_linux_arm64.tar.gz"
      sha256 "31e00d5bc1e225ac4929cfbacdae70963ebd1b5b9a70677fe78559d547602d7e"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
