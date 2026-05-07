cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.898"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.898/agentshield_0.2.898_darwin_amd64.tar.gz"
      sha256 "fe5363043d9d2066209ab32169c54c32cfadec76ddf8a71dc901d7c88072cb13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.898/agentshield_0.2.898_darwin_arm64.tar.gz"
      sha256 "630bedf452ad2b1f1ebe4f37c048a19ee7bab4f8bcc9baa83aa034fee7253b20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.898/agentshield_0.2.898_linux_amd64.tar.gz"
      sha256 "16d6402b2b040803b511f73fcf63f4c7fc3ec79f7f638facb9643b9a1717a270"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.898/agentshield_0.2.898_linux_arm64.tar.gz"
      sha256 "f6481de83d66ccb5869fd43e6f3a91884f9e6c389d34338f051e88e08119291f"
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
