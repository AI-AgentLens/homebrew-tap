cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.238"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.238/agentshield_0.2.238_darwin_amd64.tar.gz"
      sha256 "8c4cd3fdaa2f469defda3774169b6f080a7e984e97976796d93964ef74605833"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.238/agentshield_0.2.238_darwin_arm64.tar.gz"
      sha256 "e660936109cc64726af3fa8bd7322d538b8cce1bff496acb0e994fea99b64056"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.238/agentshield_0.2.238_linux_amd64.tar.gz"
      sha256 "c3a3457f3d372fa36a2fe1db570e6964ef78aaa498b4c87e9da1d431c167e7d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.238/agentshield_0.2.238_linux_arm64.tar.gz"
      sha256 "d112f7d9dcdcb0e4ca6e661f21d6c7347c5375751521248f61eeca9580e2dd9e"
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
