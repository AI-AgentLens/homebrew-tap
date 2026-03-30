cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.237"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.237/agentshield_0.2.237_darwin_amd64.tar.gz"
      sha256 "ebdcbe9130dd5c97b04c41a85c26c55aa55618b564db39b5378a8ade9a6c4bf9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.237/agentshield_0.2.237_darwin_arm64.tar.gz"
      sha256 "9842b23ee0b6c012b5f2edbfd4fb4076586e955e0e6b95c64d6cd574df28ad8f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.237/agentshield_0.2.237_linux_amd64.tar.gz"
      sha256 "7d302bb68b286348f99770cd7e84ee763603fcf68757550e9ae94f4838b8a605"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.237/agentshield_0.2.237_linux_arm64.tar.gz"
      sha256 "5e3ec57c1ac1287f32d3a47b7b5d38ce793633e7eb84fb3875540eb7a24469df"
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
