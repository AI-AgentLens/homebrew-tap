cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1401"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1401/agentshield_0.2.1401_darwin_amd64.tar.gz"
      sha256 "4ec41eda5052c6cf6f9fdaa115312a39b9afb205ed10645977fecfdbfe968a05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1401/agentshield_0.2.1401_darwin_arm64.tar.gz"
      sha256 "882d8e22d6d9917503824e72b2dc769f6533c290e759fd4dc05e9aafc391fd5b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1401/agentshield_0.2.1401_linux_amd64.tar.gz"
      sha256 "0c3539879c147265149b117cc66b283b8d18d92e65951ebb9d96a3b15e775596"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1401/agentshield_0.2.1401_linux_arm64.tar.gz"
      sha256 "acd54d1692dec6304d5170e9c9cd9c3ebd799ccf9234137c7feba879d161b959"
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
