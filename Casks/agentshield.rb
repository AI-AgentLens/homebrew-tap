cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.488"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.488/agentshield_0.2.488_darwin_amd64.tar.gz"
      sha256 "9cad79a87d61282f6278b55cbac576b75e79b03d9ad39d5c4775c33b6600c540"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.488/agentshield_0.2.488_darwin_arm64.tar.gz"
      sha256 "44c564a7ec8747db5d2177b88bff79a2c8886a5a6e20d29c8b406d024ccced5a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.488/agentshield_0.2.488_linux_amd64.tar.gz"
      sha256 "f6990401b2125d3a8a77e618b26d398d51ad4c36698233d9ca0097debd68bd18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.488/agentshield_0.2.488_linux_arm64.tar.gz"
      sha256 "5bf2df3e37184870713a642ac2963789a16ba9e615b702d1d5f7d7a6154dc289"
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
