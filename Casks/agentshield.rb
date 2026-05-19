cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1032"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1032/agentshield_0.2.1032_darwin_amd64.tar.gz"
      sha256 "3c1c5f3316f12b502041864e396d9750b76abb2506f1c4a1c06e5b1a83b3b59e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1032/agentshield_0.2.1032_darwin_arm64.tar.gz"
      sha256 "14cccd1e8c7b33a0c82ffc73d16b6217578bf8667f85bbd3c4a06c72db229ab7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1032/agentshield_0.2.1032_linux_amd64.tar.gz"
      sha256 "6160b6a024aad534e943098aa936ec31fcee6acd9193564654bc27b03defcc98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1032/agentshield_0.2.1032_linux_arm64.tar.gz"
      sha256 "ef42ebf7ffc68130dec2dd4cdad14bb25c9ac663a877bade8903d1c48b7f639d"
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
