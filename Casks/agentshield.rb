cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.330"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.330/agentshield_0.2.330_darwin_amd64.tar.gz"
      sha256 "d8ba0b9d5f182335a59182bd0fbcf92c63f9ca1fc27ac329caea23b0db6044ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.330/agentshield_0.2.330_darwin_arm64.tar.gz"
      sha256 "cf6db382ba541c622c2f47cb8c7ea1b5a8f673a5afdacce108d20f83abf796ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.330/agentshield_0.2.330_linux_amd64.tar.gz"
      sha256 "ea7b9eb10a260de1869aa996d30910a9db4a7c0b82ceecdcff158e0a3a88605d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.330/agentshield_0.2.330_linux_arm64.tar.gz"
      sha256 "b4990bb0f9e3ac039deb9c58892a89f213204f40024db6950150c0222c4bcbc4"
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
