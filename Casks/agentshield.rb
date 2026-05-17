cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1005"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1005/agentshield_0.2.1005_darwin_amd64.tar.gz"
      sha256 "defaeafe0850a5a7caffed4dd6857f2a2e8b61a31f36c557a6c25b8baa08fa62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1005/agentshield_0.2.1005_darwin_arm64.tar.gz"
      sha256 "2161d3322fa089c08028051bf4c6c0a48ac4100a9b95f5793a80b54acc66438f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1005/agentshield_0.2.1005_linux_amd64.tar.gz"
      sha256 "34381a63e0b5bc2dcfb4da73b82c5df72e4e6af2d0bd1be98d5a4166e7950833"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1005/agentshield_0.2.1005_linux_arm64.tar.gz"
      sha256 "d127a3d27170f9750c790db790a04026a421412084d79a74c1c05dcbdb93b6cd"
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
