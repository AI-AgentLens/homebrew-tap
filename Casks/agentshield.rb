cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1210"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1210/agentshield_0.2.1210_darwin_amd64.tar.gz"
      sha256 "ac96254d35e3cf1f5991d24a00bb16cdbf99a7b3ee8dee7da375ba27427f4c79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1210/agentshield_0.2.1210_darwin_arm64.tar.gz"
      sha256 "1436f35831bd5102a2a8d3e4cede338ff0a0e8c878af24d7ee981a4466edfca9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1210/agentshield_0.2.1210_linux_amd64.tar.gz"
      sha256 "5c586cb2e12b2e09b62c3d9c73ed2303c783ec332ec84f41a840cf7416e11464"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1210/agentshield_0.2.1210_linux_arm64.tar.gz"
      sha256 "aa92e422b428686ad61af5a0910d56616e5e6fe361affb924e12c6085d87fd06"
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
