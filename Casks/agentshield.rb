cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.609"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.609/agentshield_0.2.609_darwin_amd64.tar.gz"
      sha256 "d3c9db53978699de57c1df5da7e1f3dc5d3701655edb8cd4f643366c9e766952"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.609/agentshield_0.2.609_darwin_arm64.tar.gz"
      sha256 "518593163ad38eca9cd9099d09113e18dee3709b563f687714961245ef66e606"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.609/agentshield_0.2.609_linux_amd64.tar.gz"
      sha256 "8ef9d9049777e08a7c36f9d880ffb6e189127c14be10a1ba9638d416851fce7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.609/agentshield_0.2.609_linux_arm64.tar.gz"
      sha256 "d9e856ffa06653e99cf147470e0c9629e7fc31deb1e1393754e6a6a55eb3fba6"
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
