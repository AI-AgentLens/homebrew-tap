cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.590"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.590/agentshield_0.2.590_darwin_amd64.tar.gz"
      sha256 "f51707f93871ae1827ac05760998ee2644e5623e4541398edb96fc1ae720a443"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.590/agentshield_0.2.590_darwin_arm64.tar.gz"
      sha256 "54b13ca668eda39c5bba16d605c331f96cee92c662af127987579d81c3fce293"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.590/agentshield_0.2.590_linux_amd64.tar.gz"
      sha256 "f78f915ac9d1b13f9645b685329db80008134f45485a7662bd68495f78830dc4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.590/agentshield_0.2.590_linux_arm64.tar.gz"
      sha256 "e5bec05396e1793bb208273efd168993283e307602d40696a0514f9bc170f081"
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
