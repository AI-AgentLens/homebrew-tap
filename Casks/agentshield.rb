cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.612"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.612/agentshield_0.2.612_darwin_amd64.tar.gz"
      sha256 "b99cbf4f4714d3e2b3f8e4ea67a52e1ea8fcfdc5859e9c1c7d05fa9a7322dd32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.612/agentshield_0.2.612_darwin_arm64.tar.gz"
      sha256 "30056a56e5db1505bf840ddf85776b79a3db1c442ca9335a3b668561fc2b0191"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.612/agentshield_0.2.612_linux_amd64.tar.gz"
      sha256 "d8b8d823e8a03954c785cdef6f8516d3d0d6e66dfcccfbf307e598d9711537e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.612/agentshield_0.2.612_linux_arm64.tar.gz"
      sha256 "2be7791583650d4ad045ff0c4627a4f738fac6936cdcbab9de4d774b6eea525e"
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
