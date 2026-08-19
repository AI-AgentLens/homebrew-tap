cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1905"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1905/agentshield_0.2.1905_darwin_amd64.tar.gz"
      sha256 "7cbed0f80a0907ee45ed97937f92ca798258bcb3692f3ce538360f749c921f53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1905/agentshield_0.2.1905_darwin_arm64.tar.gz"
      sha256 "bace86c534783f71da3d50530f15d71eebd710d6f67ab05548d5e46675634de1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1905/agentshield_0.2.1905_linux_amd64.tar.gz"
      sha256 "c8155e4524dde19fd7e39e802a4733297a353a309a1bf28a236ce8223dbcc05e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1905/agentshield_0.2.1905_linux_arm64.tar.gz"
      sha256 "65ba97726f36c4f708d84f466807e936759cf028ade0023e2e76e0a250062413"
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
