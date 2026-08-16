cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1876"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1876/agentshield_0.2.1876_darwin_amd64.tar.gz"
      sha256 "3306ddf696c1111832d1c6ad94da3e271215c1401664bbfecf1bada9d6311146"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1876/agentshield_0.2.1876_darwin_arm64.tar.gz"
      sha256 "a00f9fb370264002f14b4fe528204c30f9d0f1553aacc5f4711e5c63e9a71707"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1876/agentshield_0.2.1876_linux_amd64.tar.gz"
      sha256 "93663d2289f137b295562d26583215d4d820695fe7014dc98b4a38fe42a4b4a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1876/agentshield_0.2.1876_linux_arm64.tar.gz"
      sha256 "d678f1f6bc17d8cc52adf914e6cfa3dcf210b9a049fbd2fb000e2553448ad590"
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
