cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1194"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1194/agentshield_0.2.1194_darwin_amd64.tar.gz"
      sha256 "66c9abe40e0884fb93107f50eab163a358fb2e3d6cb0569c27b5f48297f76146"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1194/agentshield_0.2.1194_darwin_arm64.tar.gz"
      sha256 "095ca8aa926baca93fc6c9158730c628da56a2114d7d91fd0335c70861abc32a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1194/agentshield_0.2.1194_linux_amd64.tar.gz"
      sha256 "3e4a12c9f6ec0eb9a624368378c88c3a73ffacdeed54bfbccd2fc0a96cdc70a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1194/agentshield_0.2.1194_linux_arm64.tar.gz"
      sha256 "f2a8c098d6084b2d0d9e77e7c990bec6d19fb8be6e8bc50c55a013bffb686584"
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
